import type { Metadata } from "next";
import Link from "next/link";

import { Button } from "@/components/ui/button";

export const metadata: Metadata = {
  title: "Home",
  description:
    "Shop beauty products, hair extensions and wigs at The Beauty Bar.",
};

export default function HomePage() {
  return (
    <section className="mx-auto grid w-full max-w-6xl gap-10 px-4 py-16 sm:px-6 sm:py-24 lg:grid-cols-2 lg:items-center">
      <div className="flex flex-col items-start gap-6">
        <span className="rounded-full bg-secondary px-3 py-1 text-xs font-semibold uppercase tracking-widest text-secondary-foreground">
          Placeholder
        </span>
        <h1 className="text-4xl font-semibold leading-tight tracking-tight sm:text-5xl">
          Beauty, hair and wigs, chosen with care.
        </h1>
        <p className="max-w-lg text-base text-muted-foreground">
          The real storefront arrives in Task 3: hero, featured products and
          categories read from the database.
        </p>
        <div className="flex flex-wrap gap-3">
          <Button asChild size="lg">
            <Link href="/shop">Shop all products</Link>
          </Button>
          <Button asChild size="lg" variant="outline">
            <Link href="/auth/sign-up">Create an account</Link>
          </Button>
        </div>
      </div>
      <div
        aria-hidden="true"
        className="aspect-[4/3] w-full rounded-2xl border bg-secondary/60"
      />
    </section>
  );
}