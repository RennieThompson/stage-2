import type { Metadata } from "next";

import { PagePlaceholder } from "@/components/shared/page-placeholder";

export const metadata: Metadata = {
  title: "Create product",
  description: "Add a product with images, variants and stock.",
};

export default function AdminNewProductPage() {
  return (
    <PagePlaceholder
      title="Create product"
      description="Product name, slug, description, price in kobo, category, images, variants and initial stock. A product without options gets one default variant."
      task="Task 8"
    />
  );
}