import Link from "next/link";

import { Button } from "@/components/ui/button";

const SHOP_LINKS = [
  { href: "/shop", label: "Shop" },
  { href: "/cart", label: "Cart" },
];

/**
 * Storefront header. The account menu and the live cart count arrive in later
 * tasks; for now the header keeps the brand, the shop links and the auth
 * entry points.
 */
export function SiteHeader() {
  return (
    <header className="sticky top-0 z-40 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/80">
      <div className="mx-auto flex h-16 w-full max-w-6xl items-center gap-4 px-4 sm:px-6">
        <Link
          href="/"
          className="font-heading text-xl font-semibold tracking-tight"
        >
          The Beauty Bar
        </Link>

        <nav
          aria-label="Main"
          className="hidden flex-1 items-center gap-6 text-sm md:flex"
        >
          {SHOP_LINKS.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className="text-muted-foreground transition-colors hover:text-foreground"
            >
              {link.label}
            </Link>
          ))}
        </nav>

        <div className="ml-auto flex items-center gap-2">
          <Button asChild variant="ghost" size="sm">
            <Link href="/auth/login">Log in</Link>
          </Button>
          <Button asChild size="sm">
            <Link href="/auth/sign-up">Sign up</Link>
          </Button>
        </div>
      </div>

      <nav
        aria-label="Main mobile"
        className="flex items-center gap-4 overflow-x-auto border-t px-4 py-2 text-sm md:hidden"
      >
        {SHOP_LINKS.map((link) => (
          <Link
            key={link.href}
            href={link.href}
            className="whitespace-nowrap text-muted-foreground"
          >
            {link.label}
          </Link>
        ))}
      </nav>
    </header>
  );
}