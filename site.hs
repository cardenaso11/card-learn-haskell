{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
import           Data.Monoid (mappend)
import           Hakyll


main :: IO ()
main = hakyllWith hakyllConfig $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match (fromList ["about.rst", "contact.markdown"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "tutorials/*" $ do
      route $ setExtension "html"
      compile $ pandocCompiler
        >>= loadAndApplyTemplate "templates/tutorial.html" tutCtx
        >>= loadAndApplyTemplate "templates/default.html" tutCtx
        >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            tutorials :: [Item String] <- loadAll "tutorials/*"
            let archiveCtx =
                    listField "tutorials" postCtx (pure tutorials)
                    <> constField "title" "Archives"
                    <> defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls


    match "index.html" $ do
        route idRoute
        compile $ do
            posts :: [Item String] <- recentFirst =<< loadAll "posts/*"
            tutorials :: [Item String] <- loadAll "tutorials/*"
            let indexCtx :: Context String =
                    listField "posts" postCtx (return posts) `mappend`
                    listField "tutorials" tutCtx (pure tutorials) <>
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateBodyCompiler


hakyllConfig :: Configuration
hakyllConfig = defaultConfiguration
  { destinationDirectory = "docs"
  }

postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

tutCtx :: Context String
tutCtx = defaultContext
