{-# LANGUAGE PackageImports #-}

module Hint.Type(
    DeclHint, DeclHint', ModuHint, CrossHint, Hint(..),
    module Export
    ) where

import Data.Semigroup
import Config.Type
import HSE.All  as Export
import Idea     as Export
import Prelude
import Refact   as Export
import "ghc-lib-parser" HsExtension
import "ghc-lib-parser" HsDecls

type DeclHint = Scope -> ModuleEx -> Decl_ -> [Idea]
type DeclHint' = Scope -> ModuleEx -> LHsDecl GhcPs -> [Idea]
type ModuHint = Scope -> ModuleEx -> [Idea]
type CrossHint = [(Scope, ModuleEx)] -> [Idea]

-- | Functions to generate hints, combined using the 'Monoid' instance.
data Hint {- PUBLIC -} = Hint
    { hintModules :: [Setting] -> [(Scope, ModuleEx)] -> [Idea] -- ^ Given a list of modules (and their scope information) generate some 'Idea's.
    , hintModule :: [Setting] -> Scope -> ModuleEx -> [Idea] -- ^ Given a single module and its scope information generate some 'Idea's.
    , hintDecl :: [Setting] -> Scope -> ModuleEx -> Decl SrcSpanInfo -> [Idea]
    , hintDecl' :: [Setting] -> Scope -> ModuleEx -> LHsDecl GhcPs -> [Idea]
        -- ^ Given a declaration (with a module and scope) generate some 'Idea's.
        --   This function will be partially applied with one module/scope, then used on multiple 'Decl' values.
    }

instance Semigroup Hint where
    Hint x1 x2 x3 x4 <> Hint y1 y2 y3 y4 = Hint
        (\a b -> x1 a b ++ y1 a b)
        (\a b c -> x2 a b c ++ y2 a b c)
        (\a b c d -> x3 a b c d ++ y3 a b c d)
        (\a b c d -> x4 a b c d ++ y4 a b c d)

instance Monoid Hint where
    mempty = Hint (\_ _ -> []) (\_ _ _ -> []) (\_ _ _ _ -> []) (\_ _ _ _ -> [])
    mappend = (<>)
