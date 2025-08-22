import { useCallback } from "react";
import { Pressable, Text, View } from "react-native";
import * as WebBrowser from "expo-web-browser";
import * as Linking from "expo-linking";
import { useOAuth, SignedOut } from "@clerk/clerk-expo";
import { useRouter } from "expo-router";

WebBrowser.maybeCompleteAuthSession();

export default function SignInScreen() {
  const router = useRouter();
  const { startOAuthFlow: startGoogleOAuthFlow } = useOAuth({
    strategy: "oauth_google",
  });
  const { startOAuthFlow: startAppleOAuthFlow } = useOAuth({
    strategy: "oauth_apple",
  });

  const handleOAuth = useCallback(
    async (
      startFlow: (args: { redirectUrl: string }) => Promise<{
        createdSessionId?: string;
        setActive?: (args: { session: string }) => Promise<void>;
      }>
    ) => {
      try {
        const redirectUrl = Linking.createURL("/", {
          scheme: "rippletconnect",
        });
        const { createdSessionId, setActive } = await startFlow({
          redirectUrl,
        });
        if (createdSessionId) {
          await setActive?.({ session: createdSessionId });
          router.replace("/");
        }
      } catch (err) {
        // eslint-disable-next-line no-console
        console.error("OAuth error", err);
      }
    },
    [router]
  );

  return (
    <View
      style={{
        flex: 1,
        alignItems: "center",
        justifyContent: "center",
        paddingHorizontal: 24,
        gap: 12,
      }}
    >
      <Text style={{ fontSize: 24, fontWeight: "700", marginBottom: 8 }}>
        Sign in
      </Text>
      <SignedOut>
        <Pressable
          onPress={() => handleOAuth(startAppleOAuthFlow)}
          style={{
            backgroundColor: "#000000",
            paddingVertical: 14,
            paddingHorizontal: 16,
            borderRadius: 8,
            width: "100%",
            alignItems: "center",
          }}
        >
          <Text style={{ color: "white", fontSize: 16, fontWeight: "600" }}>
            Continue with Apple
          </Text>
        </Pressable>
        <Pressable
          onPress={() => handleOAuth(startGoogleOAuthFlow)}
          style={{
            backgroundColor: "#111827",
            paddingVertical: 14,
            paddingHorizontal: 16,
            borderRadius: 8,
            width: "100%",
            alignItems: "center",
          }}
        >
          <Text style={{ color: "white", fontSize: 16, fontWeight: "600" }}>
            Continue with Google
          </Text>
        </Pressable>
      </SignedOut>
    </View>
  );
}
