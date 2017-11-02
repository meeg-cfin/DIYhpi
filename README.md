# DIYhpi

Goal: coregister the head when using homebrew techniques, i.e., not using the vendor-provided digitization method

What it does:
- extracts the HPI coils and MEG sensors in device coordinates
- when you supply the HPI coil coordinates in MRI space, it calculates a best-fit transform between device space and MRI space based on the coil locations

What it does NOT do yet but we should implement someday:
- the device2mri transform should be enforced as a rigid-body transform, i.e., no scaling/stretching/distorting in case the coordinates are poorly marked or the MRI is distorted.
- report any goodness-of-fit, etc.
