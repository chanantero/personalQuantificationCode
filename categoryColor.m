classdef categoryColor
   properties
      R
      G
      B
   end
   methods
      function c = categoryColor(r, g, b)
        c.R = r; c.G = g; c.B = b;
      end
   end
   enumeration
      undetermined (127, 127, 127)
      morningRitual   (146, 208, 80)
      eveningRitual   (146, 208, 80)
      nightRitual   (146, 208, 80)
      groceries (255, 217, 101)
      meal (255, 217, 101)
      cook (255, 217, 101)
      porn (243, 168, 117)
      recreation (255, 192, 0)
      waste (243, 168, 117)
      exercise (255, 255, 0)
      game (255, 0, 0)
      social (255, 192, 0)
      study (186, 140, 220)
      bed (0, 0, 0)
      commute (156, 195, 229)
      work (186, 140, 220)
   end
end

