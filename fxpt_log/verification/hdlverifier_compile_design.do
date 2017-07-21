# Create design library
vlib work
# Create and open project
project new . compile_project
project open compile_project
# Add source files to project
project addfile "C:/Users/Ross_admin/Desktop/FE/ModelSim_verificaton/fxpt_math/fxpt_log/source_code/vhdl/fxpt_log_compute_W33F30.vhd"
project addfile "C:/Users/Ross_admin/Desktop/FE/ModelSim_verificaton/fxpt_math/fxpt_log/source_code/vhdl/fxpt_log_ROM_b_coef_W33F30.vhd"
project addfile "C:/Users/Ross_admin/Desktop/FE/ModelSim_verificaton/fxpt_math/fxpt_log/source_code/vhdl/fxpt_log_ROM_lnb_coef_W33F30.vhd"
# Calculate compilation order
project calculateorder
set compcmd [project compileall -n]
# Close project
project close
# Compile all files and report error
if [catch {eval $compcmd}] {
    exit -code 1
}
