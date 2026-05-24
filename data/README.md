# data/

## `raw/` — experimental data (read-only)

| File | Description |
|---|---|
| `string_uniaxial_tensile_test.csv` | Uniaxial tension test of the conductive string. Column 6 = stress (MPa), Column 7 = strain (%). |
| `tensegrity_UTM_compression.xlsx`  | UTM compression of the full tensegrity structure. Column 2 = load (kgf), Column 4 = displacement (mm). Initial height = 205 mm. |
| `resistance_log_20250730.csv`      | 3-channel resistance log (R1, R2, R3 in columns 2, 4, 6). |

## `processed/` — generated outputs

These files are produced by the scripts in `src/` but are committed here so any
downstream step can be run without re-executing the full pipeline.

| File | Produced by |
|---|---|
| `string_stress_interp.mat`             | `src/material_characterization/generate_stress_interp.m` |
| `mooney_constants.mat`                 | `src/material_characterization/fit_mooney_rivlin.m`      |
| `tensegrity_sensor_model.mat`          | `src/tensegrity_model/build_tensegrity_model.m`          |
| `M4_string_forces_log_with_disp.txt`   | `src/simulation/run_compression_simulation.m`            |
