module IMGScale(
    RatioDecl(..)
  , Ratio(..)  
  , scaleImage
  , getImgRatio
  , fltDiv
  , res16_9
  , res16_10
  , res4_3
  , main
  , getCloseMatch
) where

import System.Environment
import System.FilePath.Posix
import Control.Monad

import Text.Printf

import Graphics.GD
import Graphics.Filters.GD

import Data.List
import Data.Maybe

data RatioDecl = R16_9 | R16_10 | R4_3 deriving (Show)
data Ratio = Ratio RatioDecl (Int, Int) deriving (Show)
 
main :: IO ()
main = do
    imagePath <- liftM head getArgs
    let scl = scaleImage (takeFileName imagePath)
    case takeExtension imagePath of
        ".png" -> scl =<< loadPngFile imagePath
        ".jpg" -> scl =<< loadJpegFile imagePath
        otherwise -> putStrLn $ "Unbekannte Datei-Endung: " ++ (takeExtension imagePath)

scaleImage :: FilePath -> Image -> IO ()
scaleImage imgName imgData = do
    ratio <- liftM getImgRatio $ imageSize imgData
    flip mapM_ (resSbyRatio ratio) $ \(x,y) ->
        (>>) (printf "Verarbeite Auflösung: %dx%d\n" x y)
        (savePngFile (printf "data/%d-%d-%s" x y imgName) =<<
            resizeImage x y imgData)
  where
    resSbyRatio :: Ratio -> [(Int, Int)]
    resSbyRatio (Ratio R4_3   ratio) = fFnc ratio $ res4_3
    resSbyRatio (Ratio R16_9  ratio) = fFnc ratio $ res16_9
    resSbyRatio (Ratio R16_10 ratio) = fFnc ratio $ res16_10
    fFnc (oX, oY) = filter (\(x,y) -> oX >= x && oY >= y ) 

getImgRatio :: (Int, Int) -> Ratio
getImgRatio (width, height) = case () of
    _ | rfrc (fltDiv width height) == rfrc (16 /  9) -> Ratio R16_9  (width, height )
      | rfrc (fltDiv width height) == rfrc ( 4 /  3) -> Ratio R4_3   (width, height )
      | rfrc (fltDiv width height) == rfrc (16 / 10) -> Ratio R16_10 (width, height )
      | otherwise -> Ratio R16_9 (width, height)

--todo y berücksichtigen
getCloseMatch :: (Int, Int) -> (Int, Int)
getCloseMatch (x, y) = availableRes !! (fromJust $ elemIndex (minimum (filter (\x->0<=x) (map fst $ matchMap))) (map abs (map fst $ matchMap)))
  where
    availableRes = res4_3 ++ res16_9 ++ res16_10
    matchMap = map (\(rX,rY) -> (x-rX,y-rY)) availableRes

fltDiv :: Int -> Int -> Float
fltDiv a b = (fromIntegral a) / (fromIntegral b)

rfrc :: Float -> Float
rfrc d = (fromInteger $ round $ d * (10^2)) / (10.0^^2)

res16_9 = 
  [
    (2560,1440),
    (1920,1080),
    (1600,900),
    (1366,768),
    (1280,720),
    (1024,576),
    (854,480)
  ]

res16_10 =
  [
--  (2880,1800)
    (2560,1600)
  , (1920,1200)
  , (1680,1050)
  , (1440,900)
  , (1280, 800)
  , (320, 200)
  ]

res4_3 = 
  [
    (2048,1536),
    (1600,1200),
    (1440,1080),
    (1400,1050),
    (1280,960),
    (1152,864),
    (1024,768),
    (800,600),
    (640,480)
 ]
