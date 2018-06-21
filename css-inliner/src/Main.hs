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
import Debug.Trace

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


--inline :: [NestedBlock] -> XmlTree -> Maybe XmlTree
  --doc >>> css $ unpack tag >>> addAttr "style" $ tuples2str x
--inline x doc = Just doc
--inline _  doc = Nothing
--inline (LeafBlock _) doc = Just doc
--inline (NestedBlock _ _) doc = Nothing

--tuples2str :: [NestedBlock] -> String
--tuples2str [(prop,val)] = prop ++ ":" ++ val  ++ ";" 
--tuples2str [x:xs] = tuples2str [x] ++ ";" ++ tuples2str(xs)

traceThis :: (Show a) => a -> a
traceThis x = Debug.Trace.trace (show x) x

traceShow :: (Show a) => a -> b -> b
traceShow = Debug.Trace.trace . show

debug = flip Debug.Trace.trace

main :: IO ()
main = do
  putStrLn "Started execution... \n"
  doc <- readFile "style.html"
  css <- runX (readDocument [ withValidate no] "style.html"
               >>> selectStyle /> getText)
  putStrLn "prelude.head css: \n"
  putStrLn $ Prelude.head css
  putStrLn "\n"
  -- parseNestedBlocks is the preferred parser: it captures media queries
  -- parseBlocks throws away media queries.
  parsedCss <- return $ parseNestedBlocks $ Data.Text.pack $ Prelude.head css
  putStrLn "show parsedCss: \n"
  print parsedCss
  case parsedCss of
    Left msg -> print msg
    Right(x) -> do
      print x
      putStrLn "Inlining..."
      let doc2 = inline x doc
      putStrLn "Inlining done"
  putStrLn "Done!"
