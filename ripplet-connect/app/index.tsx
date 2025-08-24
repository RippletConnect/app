import { Text, View } from "react-native";
import { useEffect } from "react";
import { useAuth } from "@clerk/clerk-expo";
import { useRouter } from "expo-router";

export default function Index() {
  const { isLoaded, isSignedIn } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!isLoaded) return;
    if (!isSignedIn) {
      router.replace("/sign-in");
      return;
    }
    router.replace("/(tabs)");
  }, [isLoaded, isSignedIn, router]);

  if (!isLoaded || !isSignedIn) {
    return null;
  }

  return null;
}
