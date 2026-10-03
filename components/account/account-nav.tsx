import Link from "next/link";

export const ACCOUNT_LINKS = [
  { href: "/account", label: "Dashboard" },
  { href: "/account/profile", label: "Profile" },
  { href: "/account/orders", label: "Orders" },
];

export function AccountNav() {
  return (
    <nav aria-label="Account" className="w-full">
      <ul className="flex flex-wrap gap-2">
        {ACCOUNT_LINKS.map((link) => (
          <li key={link.href}>
            <Link
              href={link.href}
              className="inline-flex items-center rounded-md border px-3 py-1.5 text-sm text-muted-foreground transition-colors hover:bg-accent hover:text-accent-foreground"
            >
              {link.label}
            </Link>
          </li>
        ))}
      </ul>
    </nav>
  );
}