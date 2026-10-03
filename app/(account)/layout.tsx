import { AccountNav } from "@/components/account/account-nav";
import { SiteFooter } from "@/components/layout/site-footer";
import { SiteHeader } from "@/components/layout/site-header";

export default function AccountLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex min-h-svh flex-col">
      <SiteHeader />
      <main className="flex-1">
        <div className="mx-auto w-full max-w-6xl px-4 py-10 sm:px-6">
          <h1 className="text-2xl font-semibold tracking-tight">My account</h1>
          <div className="mt-4">
            <AccountNav />
          </div>
          <div className="mt-8">{children}</div>
        </div>
      </main>
      <SiteFooter />
    </div>
  );
}