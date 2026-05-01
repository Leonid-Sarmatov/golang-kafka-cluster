{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE RecordWildCards #-}

module Main where

import Foreign.Ptr
import System.IO

import ExampleLib 
import FFI.HelloFFI
import FFI.Version

main :: IO ()
main = do
    hSetBuffering stdout NoBuffering
    putStrLn "Run program..."
    ExampleLib.bubilda
    FFI.HelloFFI.c_helloFFI
    eitherResult <- FFI.HelloFFI.modifedString "pipapupa"
    case eitherResult of
        Left e -> putStrLn $ show e
        Right str -> putStrLn "Successfull!!!" >> putStrLn str
    version <- kafkaVersion
    putStrLn version
    c_printVersion
    cb <- mkCallback callback
    c_runEventLoop cb
    freeHaskellFunPtr cb
    putStrLn "Program has been stopped"
