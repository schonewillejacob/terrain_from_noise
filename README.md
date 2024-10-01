# Terrain, From Noise
COMP360 AB1, Fall 2024, assignment 1


## Added features
- Generates a pseudorandom noise texture, using FastNoiseLite
- Maps vertexes onto a grid of surfaces, using SurfaceTool
- Noise sampling is proportional, not 1-1
- Sample noise texure to:
  -  Set vertex height, scaled for visual effect
  -  Set per-vertex colour, using sample's red channel
- Provide camera navigation

## Ideas for features
- Change noise texture to match landscape generation more closely
- Map colors to elevation
  - 0.0 - 0.1: basin, clamp height to 0.1 and change colour to blue
  - 0.1 - 0.2: beach, change colour to tan
  - 0.2 - 0.4: hillside, change colour to green, generate low-elevation trees
  - 0.4 - 0.9: mountain, change colour to brown, generate boulders + high-elevation trees
  - 0.9 - 1.0: snowy, change colour to blue-white
