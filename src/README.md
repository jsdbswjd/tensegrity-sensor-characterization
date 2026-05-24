# src/

Source code organized by pipeline stage. Run the folders in order
(`material_characterization` → `tensegrity_model` → `simulation` → `sensor_estimation`).

| Folder | Purpose |
|---|---|
| `material_characterization/` | Process the string uniaxial tension data and fit Mooney-Rivlin constants `C1`, `C2`. |
| `tensegrity_model/`          | Define nodes (`N`), bar connectivity (`C_b`), string connectivity (`C_s`), and the loading plate nodes. Saves the model as a `.mat`. |
| `simulation/`                | Solve quasi-static equilibrium under prescribed plate displacement using PVW + Mooney-Rivlin strings + linear bars. Logs per-step string and bar forces. |
| `sensor_estimation/`         | Convert measured resistance changes to strain (via per-channel `m_i` calibration with Poisson correction), then to string force via the experimental stress curve. Compares against PVW simulation. |
| `utils/`                     | Helper functions (numerical Jacobian, etc.). |
