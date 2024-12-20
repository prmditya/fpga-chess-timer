
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name timer_catur -dir "/home/ise/Documents/timer_catur/planAhead_run_3" -part xc3s500efg320-4
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "main_timer.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {main_timer.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set_property top main_timer $srcset
add_files [list {main_timer.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc3s500efg320-4
