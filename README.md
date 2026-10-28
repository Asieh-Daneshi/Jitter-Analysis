# Jitter analysis for AOSLO stimulus delivery

![MATLAB](https://img.shields.io/badge/MATLAB-0076A8?logo=mathworks&logoColor=white) ![Imaging](https://img.shields.io/badge/AOSLO-retinal%20imaging-8A2BE2) ![Method](https://img.shields.io/badge/sub--pixel-DFT%20registration-blue)

MATLAB code I wrote at the University Clinic Bonn (2021) to measure how well an adaptive-optics scanning laser ophthalmoscope (AOSLO) keeps a stimulus fixed on the retina.

In the experiments a small cross is projected onto the retina, and the system stabilises it online against eye movements. Online stabilisation is not perfect, so the stimulus still moves a little relative to the retina. This code measures that leftover motion ("jitter") frame by frame.

## How it works

For each recording it compares the raw AOSLO video with the online-stabilised video:

1. **Find the cross** in every frame of both videos (`Cross_oneFrame_November4.m`).
2. **Coarse alignment:** normalised cross-correlation (`normxcorr2`) of a patch around the cross in the stabilised frame against the raw frame.
3. **Sub-pixel registration:** the retinal patches to the left and right of the cross are registered between the two videos with the efficient sub-pixel DFT method of Guizar-Sicairos et al. (2008), `dftregistration.m`, upsampling factor 1000. The two estimates are averaged.
4. **Clean-up:** frames without a detectable cross, or with the cross too close to the border, are skipped; frame-to-frame jumps larger than 2 pixels are marked as missing.

## Use

Run `main.m` in MATLAB, select one or more raw videos (`*.avi`; the stabilised video must sit next to each one as `<name>_stabilized.avi`), and enter the first and last frame to analyse. For each video it saves `<name>_motion.mat`, `<name>_jitter.mat` and `<name>_finalShift.mat`, and plots the horizontal and vertical shift over time.

## Files

| File | Purpose |
|---|---|
| `main.m` | entry point: file selection, loop over videos, saving and plotting |
| `MotionAnalyze_April15.m` | per-frame cross detection, cross-correlation and sub-pixel registration |
| `Cross_oneFrame_November4.m` | finds the stimulus cross in one frame |
| `sumNormMaker_April15.m` | helper used in the analysis |
| `dftregistration.m` | sub-pixel registration by Manuel Guizar-Sicairos (third-party, see the file header) |

## Reference

M. Guizar-Sicairos, S. T. Thurman and J. R. Fienup, "Efficient subpixel image registration algorithms," *Optics Letters* 33, 156-158 (2008).

This is research code, kept as it was used in the lab. The raw AOSLO recordings are not included.
