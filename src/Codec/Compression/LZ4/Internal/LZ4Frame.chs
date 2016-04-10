{-# LANGUAGE CPP, ForeignFunctionInterface #-}
module Codec.Compression.LZ4.Internal.LZ4Frame where

#include "lz4frame.h"

import Data.String
import Data.Word
import Foreign.Ptr
import Foreign.C.Types
import Foreign.C.String

{#context prefix = "LZ4F_"#}

version :: Int
version = {#const LZ4F_VERSION#}
{#enum blockSizeID_t as BlockSizeID {upcaseFirstLetter}
  omit (max64KB, max256KB, max1MB, max4MB)
  deriving (Show)#}
{#enum blockMode_t as BlockMode {upcaseFirstLetter}
  omit (blockLinked, blockIndependent)
  deriving (Show)#}
{#enum contentChecksum_t as ContentChecksum {upcaseFirstLetter}
  omit (noContentChecksum, contentChecksumEnabled)
  deriving (Show)#}
{#enum frameType_t as FrameType {upcaseFirstLetter}
  omit (skippableFrame)
  deriving (Show)#}

type VoidPtr = Ptr ()
type SizeTPtr = Ptr CSize
type ErrorCode = CSize

-- Write storable instance. do not forget to end-pad with reserved: unsigned[2]
data FrameInfo = FrameInfo
 { blockSizeId  :: BlockSizeID
 , blockMode    :: BlockMode
 , checksumFlag :: ContentChecksum
 , frameType    :: FrameType
 , contentSize  :: Word64}

-- Write storable instance. do not forget to end-pad with reserved: unsigned[4]
data Prefs = Prefs
  { frameInfo        :: FrameInfo
  , compressionLevel :: Int
  , autoFlush        :: Bool }

-- Write storable instance. do not forget to end-pad with resperved: unsigned[3]
data CompressOpts = CompressOpts
    { stableSrc :: Word }

-- Write storable instance. do not forget to end-pad with reserved: unsigned[3]
data DecompressOpts = DecompressOpts
    { stableDst :: Word}

{#pointer *frameInfo_t as FrameInfoPtr newtype #}
{#pointer *preferences_t as PrefsPtr newtype #}
{#pointer *compressOptions_t as CompressOptsPtr newtype #}
{#pointer *decompressOptions_t as DecompressOptsPtr newtype #}
-- Opaque pointer type. Must be 8-byte aligned, but this is opaque to us.
{#pointer compressionContext_t as CompressionCxt newtype #}
{#pointer *compressionContext_t as CompressionCxtPtr newtype #}
{#pointer decompressionContext_t as DecompressionCxt newtype #}
{#pointer *decompressionContext_t as DecompressionCxtPtr #}

{#fun pure unsafe isError as ^
  { fromIntegral `ErrorCode' fromIntegral } -> `Word' fromIntegral #}
{#fun pure unsafe getErrorName as ^
  { fromIntegral `ErrorCode' fromIntegral } -> `CString' fromString #}
{#fun unsafe compressFrameBound as ^
  { fromIntegral `CSize' fromIntegral
  , id `PrefsPtr' id} -> `CSize' fromIntegral #}
{#fun unsafe compressFrame as ^
  { id `VoidPtr' id
  , fromIntegral `CSize' fromIntegral
  , id `VoidPtr' id
  , fromIntegral `CSize' fromIntegral
  , id `PrefsPtr' id } -> `CSize' fromIntegral #}
{#fun unsafe createCompressionContext as ^
  { id `CompressionCxtPtr' id
  , fromIntegral `Word' fromIntegral } -> `ErrorCode' id #}
{#fun unsafe freeCompressionContext as ^
  { id `CompressionCxt' id } -> `ErrorCode' id #}
{#fun unsafe compressBegin as ^
  { id `CompressionCxt' id
  , id `VoidPtr' id
  , fromIntegral `CSize' fromIntegral
  , id `PrefsPtr' id } -> `ErrorCode' id #}
{#fun unsafe compressBound as ^
  { fromIntegral `CSize' fromIntegral
  , id `PrefsPtr' id } -> `CSize' fromIntegral #}
{#fun unsafe compressUpdate as ^
  { id `CompressionCxt' id
  , id `VoidPtr' id
  , fromIntegral `CSize' fromIntegral
  , id `VoidPtr' id
  , fromIntegral `CSize' fromIntegral
  , id `CompressOptsPtr' id } -> `ErrorCode' id #}
{#fun unsafe flush as ^
  { id `CompressionCxt' id
  , id `VoidPtr' id
  , fromIntegral `CSize' fromIntegral
  , id `CompressOptsPtr' id } -> `ErrorCode' id #}
{#fun unsafe compressEnd as ^
  { id `CompressionCxt' id
  , id `VoidPtr' id
  , fromIntegral `CSize' fromIntegral
  , id `CompressOptsPtr' id } -> `ErrorCode' id #}
{#fun unsafe createDecompressionContext as ^
  { id `DecompressionCxtPtr' id
  , fromIntegral `Word' fromIntegral} -> `ErrorCode' id #}
{#fun unsafe freeDecompressionContext as ^
  { id `DecompressionCxt' id } -> `ErrorCode' id #}
{#fun unsafe getFrameInfo as ^
  { id `DecompressionCxt' id
  , id `FrameInfoPtr' id
  , id `VoidPtr' id
  , id `SizeTPtr' id } -> `CSize' fromIntegral #}
{#fun unsafe decompress as ^
  { id `DecompressionCxt' id
  , id `VoidPtr' id
  , id `SizeTPtr' id
  , id `VoidPtr' id
  , id `SizeTPtr' id
  , id `DecompressOptsPtr' id } -> `CSize' fromIntegral #}
