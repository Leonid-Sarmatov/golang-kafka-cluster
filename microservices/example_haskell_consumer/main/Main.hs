{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE RecordWildCards #-}

module Main where

import qualified ExampleLib (bubilda)
import qualified FFI.HelloFFI (helloFFI)

main :: IO ()
main = do
    putStrLn "Hello, World!!!"
    ExampleLib.bubilda
    FFI.HelloFFI.helloFFI
