
# set ovn port group to access public net

```bash
▶ k ko nbctl list Port_Group    ovn.default.debian       
_uuid               : 32186b78-b24c-4bea-89a7-fd065ab84764
acls                : []
external_ids        : {np="ovn-default/debian"}
name                : ovn.default.debian
ports               : [32635a43-4b6e-4d50-92d3-adfd5aea541a, 6a602078-c928-4d8c-a42d-cdfac91145c1, cf619ce8-4422-4128-ac6e-5f5956023c13]



▶ k ko nbctl list Logical_Switch_Port | grep -C 1 10.16
_uuid               : cf619ce8-4422-4128-ac6e-5f5956023c13
addresses           : ["ce:df:aa:8f:f2:1b 10.16.0.2"]
dhcpv4_options      : []
--
_uuid               : 6a602078-c928-4d8c-a42d-cdfac91145c1
addresses           : ["6e:b9:21:0c:a1:ee 10.16.0.4"]
dhcpv4_options      : []
--
_uuid               : a511d621-3132-4bb0-906b-12654a38ec68
addresses           : ["02:94:b0:9e:52:29 10.16.0.77"]
dhcpv4_options      : []
--
_uuid               : 32635a43-4b6e-4d50-92d3-adfd5aea541a
addresses           : ["7e:5f:df:46:15:65 10.16.0.3"]
dhcpv4_options      : []



k ko nbctl pg-set-ports ovn.default.debian a511d621-3132-4bb0-906b-12654a38ec68

▶  k ko nbctl list Port_Group    ovn.default.debian  
_uuid               : 32186b78-b24c-4bea-89a7-fd065ab84764
acls                : []
external_ids        : {np="ovn-default/debian"}
name                : ovn.default.debian
ports               : [a511d621-3132-4bb0-906b-12654a38ec68]

```