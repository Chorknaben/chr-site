module Gauss where
import System.Environment
import System.FilePath.Posix
import System.Process
import Control.Monad

import Text.Printf

import Graphics.GD
import Graphics.Filters.GD

import IMGScale

import Data.IORef

main :: IO ()
main = do
    imagePath <- liftM head getArgs
    let gauss = generateGaussianTiles (takeFileName imagePath)
    case takeExtension imagePath of
        ".png" -> gauss =<< loadPngFile imagePath
        ".jpg" -> gauss =<< loadJpegFile imagePath
        otherwise -> putStrLn $ "Unbekannte Datei-Endung: " ++ (takeExtension imagePath)
        
generateGaussianTiles :: String -> Image -> IO ()
generateGaussianTiles imgName imgData = do
    ratio <- liftM getImgRatio $ imageSize imgData
    tile  <- newImage $ stdtile ratio
    counter <- newIORef (0 :: Int)
    forM_ (initTiles ratio) $ \pt -> do
        incMod counter >>= \cnt ->
            blur pt tile cnt
    newImage (snd $ bigTile ratio) >>= \pt -> incMod counter >>= \cnt -> blur (bigTile ratio) pt cnt
    newImage (navtile ratio) >>= \i -> forM_ (initNav ratio) (\pt -> do
        incMod counter >>= \cnt ->
            blur pt i cnt)
  where
    blur pt t int = do
        print pt
        copyRegion (fst pt) (snd pt) imgData (0, 0) t
        savePngFile ".cache.png" t
        readProcess "/usr/bin/convert" [".cache.png", "-morphology", "Convolve", "Gaussian:28x10", ".cache.png"] []
        newt <- loadPngFile ".cache.png"
        savePngFile (printf "data/%s-%d.png" (dropExtension imgName) int) newt
    incMod c = modifyIORef c (+1) >> readIORef c
navtile ratio = (fst $ stdtile ratio, 44)

initTiles :: Ratio -> [(Point, Size)]
initTiles r@(Ratio _ (x, y)) = map (\func -> (func (fromIntegral x::Double) (fromIntegral y::Double) (stdtile r), stdtile r)) stdTiles

initNav :: Ratio -> [(Point, Size)]
initNav r@(Ratio _ (x, y)) = map (\func -> (func (fromIntegral x::Double) (fromIntegral y::Double) (stdtile r),(fst $stdtile r,44))) stdNav
  where
    navtile (Ratio _ (x, _)) = (let x1=fromIntegral x::Double in round $ (x1 - ((12.0 / 100.0) * x1)) * (20.0 / 100.0), 44)

stdTiles :: [(Double -> Double -> Size -> Point)]
stdTiles = 
    [ \x y _ -> (p6 x, 144 + (p5 y))
    , \x y (tX, _) -> (p6 x + (tX + 10), 144 + p5 y)
    , \x y (tX, _) -> (p6 x + 2 * (tX + 10), 144 + p5 y)
    , \x y (_, tY) -> (p6 x, 144 + p5 y + tY + 10)
    , \x y (tX, tY) -> (p6 x + (tX + 10), 144 + p5 y + tY + 10)
    , \x y (tX, tY) -> (p6 x + 2 * (tX + 10), 144 + p5 y + tY + 10)
    ]

stdNav :: [(Double -> Double -> Size -> Point)]
stdNav = [
      \x y (tX, _) -> (p6 x , 90 + p5 y)
    , \x y (tX, _) -> (p6 x + (tX + 10), 90 + p5 y)
    , \x y (tX, _) -> (p6 x + 2 * (tX + 10), 90 + p5 y)
    , \x y (tX, _) -> (p6 x + 3 * (tX + 10), 90 + p5 y)
    , \x y (tX, _) -> (p6 x + 4 * (tX), 90 + p5 y)
    ]

bigTile :: Ratio -> (Point, Size)
bigTile r@(Ratio _ (v, b)) = run (fromIntegral v::Double) (fromIntegral b::Double) (stdtile r)
  where 
    run x y (tX, tY) = (
        (p6 x + 3 * (tX + 10), 144 + p5 y)
      , (round $ x * 0.88 * 0.4, tY * 2 + 10))

p6 x = round $ (6.0 / 100.0) * x
p5 x = round $ (5.0 / 100.0) * x 

p_t1 :: Ratio -> (Point, Size)
p_t1 r@(Ratio _ (x, y)) = let x1 = fromIntegral x::Double
                              y1 = fromIntegral y::Double in
    ((round$(6.0/100.0) * x1, 90 + 44 + 10 + (round$((5.0/100.0)*y1)))
    , stdtile r )


stdtile :: Ratio -> Size
stdtile (Ratio _ (x, _)) = (xwidth, (round $ (fromIntegral xwidth :: Double) * (1 / phi)))
  where 
    xwidth = let x1=fromIntegral x::Double in round$ (x1 - ((12.0 / 100.0) * x1)) * (20.0 / 100.0)

fltDiv :: Int -> Int -> Float
fltDiv a b = (fromIntegral a) / (fromIntegral b)

phi :: Double
phi = 1.618033988749894
