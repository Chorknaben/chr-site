{-# LANGUAGE OverloadedStrings, DoAndIfThenElse #-}

------------------------------------------------------------------------------
-- | This module is where all the routes and handlers are defined for your
-- site. The 'app' function is the initializer that combines everything
-- together and is exported by this module.
module Site
  ( app
  ) where

------------------------------------------------------------------------------
import           Control.Applicative
import           Data.ByteString (ByteString)
import           Data.ByteString.Lazy (toStrict)
import qualified Data.Text as T
import           Snap.Core
import           Snap.Snaplet
import           Snap.Snaplet.Auth
import           Snap.Snaplet.Auth.Backends.JsonFile
import           Snap.Snaplet.Heist
import           Snap.Snaplet.Session.Backends.CookieSession
import           Snap.Util.FileServe
import           Heist
import qualified Heist.Interpreted as I

import           Graphics.GD
import           Text.Printf
import           Control.Monad.IO.Class
import qualified Data.ByteString.Char8 as BS
import           Data.Maybe
import           System.Posix.Files 

import           IMGScale
import           Data.Aeson
------------------------------------------------------------------------------
import           Application


------------------------------------------------------------------------------
-- | Render login form
handleLogin :: Maybe T.Text -> Handler App (AuthManager App) ()
handleLogin authError = heistLocal (I.bindSplices errs) $ render "login"
  where
    errs = maybe noSplices splice authError
    splice err = "loginError" ## I.textSplice err


------------------------------------------------------------------------------
-- | Handle login submit
handleLoginSubmit :: Handler App (AuthManager App) ()
handleLoginSubmit =
    loginUser "login" "password" Nothing
              (\_ -> handleLogin err) (redirect "/")
  where
    err = Just "Unknown user or password"


------------------------------------------------------------------------------
-- | Logs out and redirects the user to the site index.
handleLogout :: Handler App (AuthManager App) ()
handleLogout = logout >> redirect "/"


------------------------------------------------------------------------------
-- | Handle new user form submit
handleNewUser :: Handler App (AuthManager App) ()
handleNewUser = method GET handleForm <|> method POST handleFormSubmit
  where
    handleForm = render "new_user"
    handleFormSubmit = registerUser "login" "password" >> redirect "/"

-- Own Code

imgroot :: FilePath
imgroot = "/home/svt/code/html/chor/pa_gege/code/server/data"

getBG :: Handler App App ()
getBG = do
    -- todo serve image based on req
    -- achtung scheiße
    width <- (getParam "width" >>= \p -> return $ BS.unpack $ fromJust p ) -- >>= \p -> BS.unpack $ fromJust p
    height <- (getParam "height" >>= \p -> return $ BS.unpack $ fromJust p )
    exists <- liftIO (fileExist (printf "%s/%s-%s-chorhintergrund.png" imgroot width height))
    if exists then do
        -- serve background image
        img <- liftIO (loadPngFile (printf "%s/%s-%s-chorhintergrund.png" imgroot width height))
        liftIO (savePngByteString img) >>= writeBS
    else do
        let (closeX, closeY) = getCloseMatch (asInt width, asInt height)
        img <- liftIO (loadPngFile (printf "%s/%d-%d-chorhintergrund.png" imgroot closeX closeY))
        liftIO (savePngByteString img) >>= writeBS


        -- get nearest background image
        -- file generation request
asInt :: String -> Int
asInt a = (read a) :: Int

getTile :: Handler App App ()
getTile = do
    width <- unsafeDecode "width"
    height <- unsafeDecode "height"
    tileID <- unsafeDecode "tileID"
    exists <- liftIO (fileExist (printf "%s/%s-%s-chorhintergrund.-%s.png" imgroot width height tileID))
    if exists then do
        -- serve background tiles
        img <- liftIO (loadPngFile (printf "%s/%s-%s-chorhintergrund-%s.png" imgroot width height tileID))
        liftIO (savePngByteString img) >>= writeBS
    else do
        let (closeX, closeY) = getCloseMatch (asInt width, asInt height)
        img <- liftIO (loadPngFile (printf "%s/%d-%d-chorhintergrund-%s.png" imgroot closeX closeY tileID))
        liftIO (savePngByteString img) >>= writeBS

unsafeDecode :: MonadSnap m => ByteString -> m [Char]
unsafeDecode a = getParam a >>= \p -> return $ BS.unpack $ fromJust p 

--handleBackend :: Handler App App ()
--handleBackend = do
--todo create backend
    
data HandlerResponse = HandlerResponse
    { numtiles :: Int
    }

instance ToJSON HandlerResponse where
    toJSON (HandlerResponse numtiles) = object ["numtiles" .= numtiles]
    
-- Eigene Handler
handleHandler :: Handler App App ()
handleHandler = do
    hdlType <- unsafeDecode "type"
    what    <- getParam "what"
    --modifyResponse (\x ->
    --    addHeader 
    --)
    case hdlType of
        "images" -> imgHandler what
        otherwise-> writeBS "Kein Handler mit diesem Namen..."

imgHandler :: Maybe BS.ByteString -> Handler App App ()
imgHandler Nothing  = return () -- maybe all?
imgHandler (Just b) = case b of
    "num" -> writeBS $ toStrict $ encode (HandlerResponse {numtiles = 45})
    

------------------------------------------------------------------------------
-- | The application's routes.
routes :: [(ByteString, Handler App App ())]
routes = [ ("/login",    with auth handleLoginSubmit)
         , ("/logout",   with auth handleLogout)
         , ("/new_user", with auth handleNewUser)
         --, ("/backend/bg",  handleBackend)
         , ("/handler/:type/:what", handleHandler)
         , ("/:width/:height/bg", getBG)
         , ("/:width/:height/:tileID", getTile)
         , ("",          serveDirectory "static")
         ]


------------------------------------------------------------------------------
-- | The application initializer.
app :: SnapletInit App App
app = makeSnaplet "app" "An snaplet example application." Nothing $ do
    h <- nestSnaplet "" heist $ heistInit "templates"
    s <- nestSnaplet "sess" sess $
           initCookieSessionManager "site_key.txt" "sess" (Just 3600)

    -- NOTE: We're using initJsonFileAuthManager here because it's easy and
    -- doesn't require any kind of database server to run.  In practice,
    -- you'll probably want to change this to a more robust auth backend.
    a <- nestSnaplet "auth" auth $
           initJsonFileAuthManager defAuthSettings sess "users.json"
    addRoutes routes
    addAuthSplices h auth
    return $ App h s a

