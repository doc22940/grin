{-# LANGUAGE OverloadedStrings, QuasiQuotes #-}
module Transformations.Simplifying.RegisterIntroductionSpec where

import Control.Monad
import Test.Hspec
import Transformations.Simplifying.RegisterIntroduction
import Test.QuickCheck.Property

import Grin
import GrinTH
import Assertions
import Test hiding (asVal)


spec :: Spec
spec = do
  describe "internals" tests

  it "Example from Figure 4.17" $ do
    let before = [expr|
            l1 <- store 0
            p  <- store (CCons a b)
            u' <- foo 1 3
            q  <- store (CInt u')
            x  <- pure (CCons q p)
            l2 <- store 1
            pure 2
          |]
    let after = [expr|
            l1 <- store 0
            t1 <- pure CCons
            p  <- store (t1 a b)
            x' <- store 1
            y' <- store 3
            u' <- foo x' y'
            t2 <- pure CInt
            q  <- store (t2 u')
            t3 <- pure CCons
            x  <- pure (t3 q p)
            l2 <- store 1
            pure 2
          |]
    registerIntroduction 0 before `sameAs` after

  forM_ programGenerators $ \(name, gen) -> do
    describe name $ do
      it "transformation has effect" $ property $
        forAll gen $ \before ->
          let after = registerIntroduction 0 before
          in changed before after True


runTests :: IO ()
runTests = hspec spec
