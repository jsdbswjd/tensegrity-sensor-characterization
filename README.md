
# Tensegrity-Based Strain Sensor
### Design and Characterization of a Tensegrity-Based Strain Sensor for Large Deformations

This research focuses on the design, fabrication, and characterization of a strain sensor using a tensegrity structure and conductive elastic strings. The mechanical and electrical responses of the sensor under compressive deformation were experimentally investigated.

As an undergraduate researcher in mechanical engineering, I contributed to sensor design, prototype fabrication, experimental measurements, MATLAB-based modeling, and data analysis. The research findings were published in a peer-reviewed journal article, for which I served as a co-first author.

**Key Technologies:** Tensegrity · 3D Printing · Strain Sensing · MATLAB · Hyperelastic Modeling · Experimental Characterization

## Sensor Structure

<p align="center">
  <img src="https://github.com/user-attachments/assets/393c0337-2078-45cb-918b-6a83f3c86f6c" width="550" alt="Tensegrity sensor structure" />
</p>


*Three-stage tensegrity sensor consisting of PLA compression members and TPU elastic strings.*

Tensegrity structures maintain their stability through the equilibrium of compression and tension members. In this study, the sensor response was characterized by measuring string elongation and electrical resistance changes induced by compressive deformation of the structure.

## Publication

**Design and Characterization of a Tensegrity-Based Strain Sensor for Large Deformations**

Yunjeong Kim, Nasu Kim, Namjung Kim  
*International Journal of Precision Engineering and Manufacturing*, 2026

- **Authorship:** Co-first author
- **DOI:** https://doi.org/10.1007/s12541-026-01579-5

## My Contributions

| Area | Contributions |
| --- | --- |
| Sensor Design & Fabrication | Designed the tensegrity structure, fabricated PLA and TPU components, and assembled the sensor prototype |
| Experiments & Measurements | Conducted string tensile tests, structural compression tests, resistance measurements, and data acquisition |
| MATLAB Modeling | Analyzed string material properties, fitted the Mooney–Rivlin hyperelastic model, and performed structural response analysis based on the Principle of Virtual Work (PVW) |
| Data Analysis | Compared experimental and analytical results, estimated string forces from resistance changes, and visualized the results |
| Manuscript Preparation | Organized experimental and analytical findings, prepared figures, and contributed to manuscript writing |

## Experiments and Analysis

### Material Characterization and Structural Response

<p align="center">
  <img src="https://github.com/user-attachments/assets/32454a72-a4b4-40f4-a54b-402b6029a5a2" height="350" alt="Experimental setup 1" />
  <img src="https://github.com/user-attachments/assets/7f7da2c7-5be2-450c-8542-ad443f6d7adf" height="350" alt="Experimental setup 2" />
</p>



*Experimental setup for characterizing the material properties of the strings and measuring the compression and resistance responses of the tensegrity structure.*

Stress–strain relationships were obtained from tensile test data, and the hyperelastic behavior of the strings was modeled using the Mooney–Rivlin model.

Structural compression tests and electrical resistance measurements were then performed to investigate the sensor response under compressive deformation.

### Comparison of Experimental and Analytical Results

<p align="center">
  <img src="https://github.com/user-attachments/assets/eb8e29f7-eed7-44f1-97a6-38ac3c69011b" width="750" alt="Comparison of experimental and analytical results" />
</p>

*Representative comparison between experimental measurements and MATLAB-based analytical results.*

The internal forces of the tensegrity structure were calculated using compression analysis based on the Principle of Virtual Work (PVW).

String strain and force were estimated from measured electrical resistance changes. These results were used to investigate the relationship between mechanical deformation and electrical sensor responses.

## Code and Data

This repository contains MATLAB analysis scripts and experimental datasets used in the research.

| Path | Description |
| --- | --- |
| [`data/raw/`](data/raw/) | Raw data from string tensile tests, structural compression tests, and resistance measurements |
| [`data/processed/`](data/processed/) | Material model parameters and intermediate analytical results |
| [`src/material_characterization/`](src/material_characterization/) | Stress–strain data processing and Mooney–Rivlin model fitting |
| [`src/tensegrity_model/`](src/tensegrity_model/) | Definition of tensegrity nodes and structural members |
| [`src/simulation/`](src/simulation/) | Compression analysis based on the Principle of Virtual Work |
| [`src/sensor_estimation/`](src/sensor_estimation/) | Estimation of string strain and force from resistance changes |
| [`figures/`](figures/) | Scripts for generating result figures |

**Software:** MATLAB, Optimization Toolbox, Signal Processing Toolbox
