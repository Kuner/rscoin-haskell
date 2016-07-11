-- | Web part of Explorer.

module RSCoin.Explorer.Web
       ( application
       ) where

import           Network.Wai                    (Application)
import           Network.Wai.Handler.WebSockets (websocketsOr)
import qualified Network.WebSockets             as WS

import           RSCoin.Explorer.AcidState      (State)
import           RSCoin.Explorer.Channel        (Channel)
import           RSCoin.Explorer.Web.Servant    (servantApp)
import           RSCoin.Explorer.Web.Sockets    (wsApp)

application :: Channel -> State -> Application
application channel st =
    websocketsOr WS.defaultConnectionOptions (wsApp channel st) (servantApp st)
