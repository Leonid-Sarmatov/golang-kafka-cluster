{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE RecordWildCards #-}

{-# LANGUAGE ForeignFunctionInterface #-}

module FFI.HelloFFI where

foreign import ccall "hello_ffi"
  helloFFI :: IO ()