{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE RecordWildCards #-}

module Main where

import Foreign.Ptr

import ExampleLib 
import FFI.HelloFFI

main :: IO ()
main = do
    putStrLn "Run program..."
    ExampleLib.bubilda
    FFI.HelloFFI.c_helloFFI
    eitherResult <- FFI.HelloFFI.modifedString "pipapupa"
    case eitherResult of
        Left e -> putStrLn $ show e
        Right str -> putStrLn "Successfull!!!" >> putStrLn str
    cb <- mkCallback callback
    c_runEventLoop cb
    freeHaskellFunPtr cb
    putStrLn "Program has been stopped"
