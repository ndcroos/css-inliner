{-# LANGUAGE OverloadedStrings #-}

module Main where

import Text.XML.HXT.Core
import Text.HandsomeSoup
import Options.Applicative
import Data.Semigroup ((<>))
import Text.Parsec
import Text.Parsec.String
import Text.CSS.Parse
import Text.CSS.Render
import Data.Typeable
import Text.HTML.TagSoup
import Data.Text

data Input = FileInput FilePath

--fileInput :: Parser Input
{-fileInput = FileInput <$> strOption
  (  long "file"
  <> short 'f'
  <> metavar "FILENAME"
  <> help "Input file" )
-}

--input :: Parser Input
--input = fileInput

--run :: Input -> IO ()
--run =

selectStyle :: ArrowXml a => a XmlTree XmlTree
selectStyle = deep (isElem >>> hasName "style")

--styleText :: ArrowXml a => a XmlTree String
--styleText = selectStyle >>> getText

data Block = Rule { tag :: Text,
                    pairs :: [Text,Text]
                    }
                  
-- inline
inline :: Block -> XmlTree -> XmlTree
inline block, doc =
           doc >>> css $ unpack tag >>> addAttr "style" $ pairs2str pairs

--
tuples2str :: [(Text,Text)] -> String
tuples2str (prop,val) = prop ++ ":" ++ val  ++ ";" 
tuples2str x:xs = tuples2str  ++ ";" ++ tuples2str(xs)

main :: IO ()
main = do
  putStrLn "Started execution... \n"
  doc <- readFile "style.html"
  css <- runX (readDocument [ withValidate no] "style.html"
               >>> selectStyle /> getText)
  putStrLn $ Prelude.head css
  putStrLn "\n"
  parsedCss <- return $ parseBlocks $ Data.Text.pack $ Prelude.head css
  print parsedCss
  case parsedCss of
    Left msg -> print msg
    Right(x) -> do
      putStrLn "Inlining..."
      inlined = inline(x, doc)
      putStrLn "Inlining done"
  
  putStrLn "Done!"
