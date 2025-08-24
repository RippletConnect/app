import { Pressable, Text, View } from "react-native";
import { useAuth } from "@clerk/clerk-expo";
import { useRouter } from "expo-router";

export default function SettingsScreen() {
  const { signOut } = useAuth();
  const router = useRouter();

  const handleSignOut = async () => {
    try {
      await signOut();
      router.replace("/sign-in");
    } catch (err) {
      console.error("Sign out error", err);
    }
  };

  return (
    <View
      style={{
        flex: 1,
        justifyContent: "center",
        alignItems: "center",
        paddingHorizontal: 24,
        gap: 12,
      }}
    >
      <Text style={{ fontSize: 20, fontWeight: "700" }}>Settings</Text>
      <Pressable
        onPress={handleSignOut}
        style={{
          backgroundColor: "#ef4444",
          paddingVertical: 12,
          paddingHorizontal: 16,
          borderRadius: 8,
        }}
      >
        <Text style={{ color: "white", fontSize: 16, fontWeight: "600" }}>
          Sign out
        </Text>
      </Pressable>
    </View>
  );
}
