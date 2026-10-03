import type { Metadata } from "next";

import { PagePlaceholder } from "@/components/shared/page-placeholder";

export const metadata: Metadata = {
  title: "Shop",
  description: "Browse every beauty product, hair extension and wig.",
};

export default function ShopPage() {
  return (
    <PagePlaceholder
      title="Shop"
      description="The full product catalog with search, filters and sorting. Products come from the database, never from hard-coded data."
      task="Task 3"
    />
  );
}