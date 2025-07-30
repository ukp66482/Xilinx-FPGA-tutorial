# HDMI TX
set_property -dict {PACKAGE_PIN L17 IOSTANDARD TMDS_33} [get_ports {TMDS_Clk_n_0}];
set_property -dict {PACKAGE_PIN L16 IOSTANDARD TMDS_33} [get_ports {TMDS_Clk_p_0}]; 
set_property -dict {PACKAGE_PIN K18 IOSTANDARD TMDS_33} [get_ports {TMDS_Data_n_0[0]}]; 
set_property -dict {PACKAGE_PIN K17 IOSTANDARD TMDS_33} [get_ports {TMDS_Data_p_0[0]}]; 
set_property -dict {PACKAGE_PIN J19 IOSTANDARD TMDS_33} [get_ports {TMDS_Data_n_0[1]}]; 
set_property -dict {PACKAGE_PIN K19 IOSTANDARD TMDS_33} [get_ports {TMDS_Data_p_0[1]}]; 
set_property -dict {PACKAGE_PIN H18 IOSTANDARD TMDS_33} [get_ports {TMDS_Data_n_0[2]}]; 
set_property -dict {PACKAGE_PIN J18 IOSTANDARD TMDS_33} [get_ports {TMDS_Data_p_0[2]}]; 