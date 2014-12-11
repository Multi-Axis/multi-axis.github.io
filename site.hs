--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll


--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do

    match "javaunit/**" $ do
        route idRoute
        compile copyFileCompiler

    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "topics/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/topic.html"   defaultContext
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "index.html" $ do
        route idRoute
        compile $ do
            items <- chronological =<< loadAll "topics/*"
            let indexCtx =
                    listField "items" defaultContext (return items) `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler
