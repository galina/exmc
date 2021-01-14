# Exmc

Example SMSC server.

## Usage

To start MC server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server`


Now you can send SMPP pdus into MC server:

```shell
echo -n -e '\x00\x00\x00\x30\x00\x00\x00\x09\x00\x00\x00\x00\x00\x00\x00\x01\x74\x65\x73\x74\x5F\x6D\x6F\x33\x00\x59\x37\x6C\x48\x7A\x76\x46\x6A\x00\x63\x6F\x6D\x6D\x00\x7B\x01\x02\x72\x61\x6E\x67\x65\x00\x00\x00\x00\x47\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00\x00\x00\x05\x00\x66\x72\x6f\x6d\x00\x01\x01\x74\x6f\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x0d\x73\x68\x6f\x72\x74\x5f\x6d\x65\x73\x73\x61\x67\x65\x04\x24\x00\x0f\x6d\x65\x73\x73\x61\x67\x65\x5f\x70\x61\x79\x6c\x6f\x61\x64' | nc 127.0.0.1 2775
```

```elixir
[info] run session #PID<0.526.0>
[info] got bind bind_transceiver %SMPPEX.Pdu{command_id: 9, command_status: 0, mandatory: %{addr_npi: 2, addr_ton: 1, address_range: "range", interface_version: 123, password: "Y7lHzvFj", system_id: "test_mo3", system_type: "comm"}, optional: %{}, ref: #Reference<0.4185321482.1794375683.49411>, sequence_number: 1}
[debug] got submit_sm %SMPPEX.Pdu{command_id: 4, command_status: 0, mandatory: %{data_coding: 0, dest_addr_npi: 1, dest_addr_ton: 1, destination_addr: "to", esm_class: 0, priority_flag: 0, protocol_id: 0, registered_delivery: 0, replace_if_present_flag: 0, schedule_delivery_time: "", service_type: "", short_message: "short_message", sm_default_msg_id: 0, sm_length: 13, source_addr: "from", source_addr_npi: 0, source_addr_ton: 5, validity_period: ""}, optional: %{1060 => "message_payload"}, ref: #Reference<0.4185321482.1794375686.48312>, sequence_number: 0}
[info] Session #PID<0.526.0> stopped with reason: :socket_closed, lost_pdus: []
[error] GenServer #PID<0.526.0> terminating
** (stop) :socket_closed
```

Or send deliver_sm to bound client using http api:

```shell
$ curl -X POST -H "content-type: application/json" -d '{"system_id": "test", "src": "123", "dst": "79123456789", "text": "text"}' http://localhost:4000/api/message;echo
{"result":"ok"}
```
