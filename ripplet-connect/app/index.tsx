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
    }
  }, [isLoaded, isSignedIn, router]);

  if (!isLoaded || !isSignedIn) {
    return null;
  }

  return (
    <View
      style={{
        flex: 1,
        justifyContent: "center",
        alignItems: "center",
      }}
    >
      <Text>Welcome!</Text>
    </View>
  );
}
