{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE RecordWildCards #-}

module Main where

import qualified ExampleLib (bubilda)
import qualified FFI.HelloFFI (c_helloFFI, modifedString)

main :: IO ()
main = do
    putStrLn "Run program..."
    ExampleLib.bubilda
    FFI.HelloFFI.c_helloFFI
    eitherResult <- FFI.HelloFFI.modifedString "pipapupa"
    case eitherResult of
        Left e -> putStrLn $ show e
        Right str -> putStrLn "Successfull!!!" >> putStrLn str
    putStrLn "Program has been stopped"
