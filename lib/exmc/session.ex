defmodule Exmc.Session do
  @moduledoc false

  use SMPPEX.Session

  require Logger

  defstruct [
    delivery_report_delay_ms: 200
  ]

  def send_message(system_id, message) do
    case Registry.lookup(SessionRegistry, system_id) do
      [] ->
        {:error, :nosession}

      sessions ->
        deliver_sm = SMPPEX.Pdu.Factory.deliver_sm(message[:src], message[:dst], message[:text])
        {session, _} = Enum.at(sessions, 0)

        SMPPEX.TransportSession.call(session, {:deliver, deliver_sm})
    end
  end

  @impl true
  def init(_socket, _transport, _opts) do
    Logger.info("run session #{inspect(self())}")

    {:ok, %__MODULE__{}}
  end

  @impl true
  def handle_call({:deliver, deliver}, _from, %__MODULE__{} = state) do
    {:reply, :ok, [deliver], state}
  end

  @impl true
  def handle_pdu(pdu, %__MODULE__{} = state) do
    handle_pdu(SMPPEX.Pdu.command_name(pdu), pdu, state)
  end

  defp handle_pdu(:submit_sm, %SMPPEX.Pdu{} = pdu, %__MODULE__{} = state) do
    Logger.debug("got submit_sm #{inspect(pdu)}")

    message_id = Exmc.Pdu.generate_message_id()
    schedule_delivery_report(pdu, message_id, state)

    submit_sm_resp = SMPPEX.Pdu.Factory.submit_sm_resp(0, message_id)

    {:ok, [SMPPEX.Pdu.as_reply_to(submit_sm_resp, pdu)], state}
  end

  defp handle_pdu(:deliver_sm, pdu, %__MODULE__{} = state) do
    Logger.debug("got deliver_sm #{inspect(pdu)}")

    resp = SMPPEX.Pdu.as_reply_to(SMPPEX.Pdu.Factory.deliver_sm_resp(0), pdu)

    {:ok, [resp], state}
  end

  @bind_pdu_types [:bind_receiver, :bind_transmitter, :bind_transceiver]

  defp handle_pdu(type, bind_pdu, %__MODULE__{} = state)
       when type in @bind_pdu_types do
    system_id = SMPPEX.Pdu.mandatory_field(bind_pdu, :system_id)

    Logger.metadata(system_id: system_id)
    Logger.info("got bind #{type} #{inspect(bind_pdu)}")

    code = SMPPEX.Pdu.Errors.code_by_name(:ROK)
    bind_resp = SMPPEX.Pdu.as_reply_to(Exmc.Pdu.bind_resp(type, code), bind_pdu)

    Registry.register(SessionRegistry, system_id, self())

    {:ok, [bind_resp], state}
  end

  defp handle_pdu(:unbind, pdu, %__MODULE__{} = state) do
    resp = SMPPEX.Pdu.as_reply_to(SMPPEX.Pdu.Factory.unbind_resp(), pdu)

    {:ok, [resp], state}
  end

  defp handle_pdu(type, pdu, %__MODULE__{} = state) do
    Logger.warn("got unexpected #{type} #{inspect(pdu)}")

    {:ok, state}
  end

  @impl true
  def handle_info({:send_pdu, pdu}, %__MODULE__{} = state) do
    Logger.debug("sending pdu #{inspect(pdu)}")

    {:noreply, [pdu], state}
  end

  @impl true
  def handle_unparsed_pdu(%SMPPEX.RawPdu{} = pdu, error, %__MODULE__{} = state) do
    Logger.warn("unparsed pdu #{inspect(error)} #{inspect(pdu)}")
    {:ok, state}
  end

  defp schedule_delivery_report(%SMPPEX.Pdu{} = pdu, message_id, %__MODULE__{} = state) do
    SMPPEX.Pdu.mandatory_field(pdu, :registered_delivery) == 1 &&
      :timer.send_after(state.delivery_report_delay_ms, self(),
        {:send_pdu, Exmc.Pdu.delivery_report(pdu, message_id)})
  end
end
