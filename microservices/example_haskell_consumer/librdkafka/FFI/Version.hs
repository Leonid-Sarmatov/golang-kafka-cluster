{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE RecordWildCards #-}

{-# LANGUAGE ForeignFunctionInterface #-}

module FFI.Version where

import Foreign.C.String
import Foreign.Ptr
import Control.Exception

foreign import ccall "print_version"
  c_printVersion :: IO ()

foreign import ccall "rd_kafka_version_str"
  c_rdKafkaVersionStr :: IO CString

kafkaVersion :: IO String
kafkaVersion = c_rdKafkaVersionStr >>= 
  (\versionstr -> peekCString versionstr) >>= 
    (\s -> return $ "[FFI]: librdkafka version = " ++ s)
