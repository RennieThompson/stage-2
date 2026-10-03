import type { Metadata } from "next";

import { PagePlaceholder } from "@/components/shared/page-placeholder";

export const metadata: Metadata = {
  title: "Profile",
  description: "Manage your name and contact details.",
};

export default function AccountProfilePage() {
  return (
    <PagePlaceholder
      title="Profile"
      description="Name, phone number and default address. Writes go through a Server Action that validates the input with Zod."
      task="Task 7"
    />
  );
}