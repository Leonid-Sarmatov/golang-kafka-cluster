{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE RecordWildCards #-}

{-# LANGUAGE ForeignFunctionInterface #-}

module FFI.HelloFFI where

import Foreign.C.String
import Foreign.C
import Foreign.Marshal.Alloc
import Foreign.Ptr
import Foreign
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
        then return (Left "[FFI ERROR]: was null pointer")
        else try (peekCString ptr) >>= (\result ->
          case result of
            Left (e :: SomeException) -> return (Left (show e))
            Right str -> return (Right str)
          )
      )
    )

data Context = Context
  { eventId :: CInt
  }

instance Storable Context where
  sizeOf :: Context -> Int
  sizeOf _ = sizeOf (undefined :: CInt)

  alignment :: Context -> Int
  alignment _ = alignment (undefined :: CInt)

  peek :: Ptr Context -> IO Context
  peek ptr = do
    eid <- peekByteOff ptr 0
    return (Context eid)

  poke :: Ptr Context -> Context -> IO ()
  poke ptr (Context eid) =
    pokeByteOff ptr 0 eid

type Callback = Ptr Context -> IO ()

foreign import ccall "wrapper"
  mkCallback :: Callback -> IO (FunPtr Callback)

foreign import ccall safe "run_event_loop"
  c_runEventLoop :: FunPtr Callback -> IO ()

callback :: Callback
callback ptr =
  handle 
  (\(e :: SomeException) -> putStrLn $ "[HASKELL EXCEPTION]: " ++ show e)
  (peek ptr >>= (\ctx -> putStrLn $ "[HASKELL]: got event: " ++ show (eventId ctx)))
