import Link from "next/link";

import { AdminNav } from "@/components/admin/admin-nav";
import { Button } from "@/components/ui/button";

export default function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex min-h-svh flex-col">
      <header className="sticky top-0 z-40 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/80">
        <div className="mx-auto flex h-16 w-full max-w-6xl items-center gap-4 px-4 sm:px-6">
          <Link href="/admin" className="flex items-baseline gap-2">
            <span className="font-heading text-lg font-semibold">
              The Beauty Bar
            </span>
            <span className="text-xs uppercase tracking-widest text-muted-foreground">
              Admin
            </span>
          </Link>
          <Button asChild variant="ghost" size="sm" className="ml-auto">
            <Link href="/">View store</Link>
          </Button>
        </div>
        <div className="mx-auto w-full max-w-6xl px-4 pb-3 sm:px-6">
          <AdminNav />
        </div>
      </header>

      <main className="flex-1">
        <div className="mx-auto w-full max-w-6xl px-4 py-8 sm:px-6">
          {children}
        </div>
      </main>

      <footer className="border-t">
        <div className="mx-auto w-full max-w-6xl px-4 py-6 text-xs text-muted-foreground sm:px-6">
          Admin access is verified on the server for every action.
        </div>
      </footer>
    </div>
  );
}