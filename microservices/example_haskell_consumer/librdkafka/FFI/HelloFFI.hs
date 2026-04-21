{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE RecordWildCards #-}

{-# LANGUAGE ForeignFunctionInterface #-}

module FFI.HelloFFI where

import Foreign.C.String
import Foreign.Marshal.Alloc
import Foreign.Ptr
import Control.Exception

foreign import ccall "hello_ffi"
  c_helloFFI :: IO ()

foreign import ccall "modifed_string"
  c_modifedString :: CString -> IO CString

modifedString :: String -> IO (Either String String)
modifedString input =
  withCString input (\cstr ->
    bracket (c_modifedString cstr) free (\ptr ->
      if ptr == nullPtr
        then return (Left "[C ERROR]: was null pointer")
        else try (peekCString ptr) >>= (\result ->
          case result of
            Left (e :: SomeException) -> return (Left (show e))
            Right str -> return (Right str)
          )
      )
    )

-- modifedString :: String -> IO String
-- modifedString input =
--   withCString input (\cstr -> c_modifedString cstr >>= 
--     (\resptr -> peekCString resptr >>= 
--       (\res -> free resptr >> return res)))

