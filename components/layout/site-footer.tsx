import Link from "next/link";

const FOOTER_LINKS = [
  {
    title: "Shop",
    links: [
      { href: "/shop", label: "All products" },
      { href: "/cart", label: "Cart" },
    ],
  },
  {
    title: "Account",
    links: [
      { href: "/account", label: "My account" },
      { href: "/account/orders", label: "My orders" },
      { href: "/auth/login", label: "Log in" },
    ],
  },
];

/**
 * Store contact details come from `store_settings` once Task 1 creates the
 * table. Until then the footer shows the values from `docs/DECISIONS.md`.
 */
export function SiteFooter() {
  return (
    <footer className="mt-auto w-full border-t bg-secondary/40">
      <div className="mx-auto grid w-full max-w-6xl gap-8 px-4 py-12 sm:px-6 md:grid-cols-4">
        <div className="flex flex-col gap-3 md:col-span-2">
          <span className="font-heading text-lg font-semibold">
            The Beauty Bar
          </span>
          <p className="max-w-sm text-sm text-muted-foreground">
            Beauty products, hair extensions and wigs, delivered across
            Nigeria.
          </p>
        </div>

        {FOOTER_LINKS.map((group) => (
          <div key={group.title} className="flex flex-col gap-3">
            <span className="text-sm font-semibold">{group.title}</span>
            <ul className="flex flex-col gap-2 text-sm text-muted-foreground">
              {group.links.map((link) => (
                <li key={link.href}>
                  <Link href={link.href} className="hover:text-foreground">
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>
        ))}
      </div>

      <div className="border-t">
        <div className="mx-auto flex w-full max-w-6xl flex-col gap-2 px-4 py-6 text-xs text-muted-foreground sm:flex-row sm:items-center sm:justify-between sm:px-6">
          <p>&copy; The Beauty Bar. All rights reserved.</p>
          <p>Prices in NGN. No online payment in version 1.</p>
        </div>
      </div>
    </footer>
  );
}