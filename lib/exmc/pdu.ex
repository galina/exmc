defmodule Exmc.Pdu do
  @moduledoc false

  def bind_resp(:bind_transmitter, code), do: SMPPEX.Pdu.Factory.bind_transmitter_resp(code)
  def bind_resp(:bind_receiver, code), do: SMPPEX.Pdu.Factory.bind_receiver_resp(code)
  def bind_resp(:bind_transceiver, code), do: SMPPEX.Pdu.Factory.bind_transceiver_resp(code)

  def generate_message_id, do: to_string(:os.system_time(:nanosecond))

  def delivery_report(%SMPPEX.Pdu{} = pdu, message_id) do
    now = NaiveDateTime.utc_now()
    timestamp = NaiveDateTime.truncate(now, :second)

    message =
      "id:#{message_id} sub:001 dlvrd:001 submit date:#{timestamp} " <>
      "done date:#{timestamp} stat:DELIVERED err:600 TEXT:"

    {:ok, command_id} = SMPPEX.Protocol.CommandNames.id_by_name(:deliver_sm)

    SMPPEX.Pdu.new(
      command_id,
      %{
        source_addr: SMPPEX.Pdu.mandatory_field(pdu, :destination_addr),
        source_addr_ton: SMPPEX.Pdu.mandatory_field(pdu, :dest_addr_ton),
        source_addr_npi: SMPPEX.Pdu.mandatory_field(pdu, :dest_addr_npi),
        destination_addr: SMPPEX.Pdu.mandatory_field(pdu, :source_addr),
        dest_addr_ton: SMPPEX.Pdu.mandatory_field(pdu, :source_addr_ton),
        dest_addr_npi: SMPPEX.Pdu.mandatory_field(pdu, :source_addr_npi),
        short_message: message,
        data_coding: SMPPEX.Pdu.mandatory_field(pdu, :data_coding),
        esm_class: 0b100
      },
      %{
        message_state: SMPPEX.Pdu.MessageState.code_by_name(:DELIVERED),
        receipted_message_id: message_id
      }
    )
  end
end
