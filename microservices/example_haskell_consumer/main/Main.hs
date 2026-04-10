module Main where

import qualified ExampleLib (bubilda)

main :: IO ()
main = do
    putStrLn "Hello, World!!!"
    ExampleLib.bubilda
