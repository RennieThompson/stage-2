export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.18"
  }
  graphql_public: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      graphql: {
        Args: {
          extensions?: Json
          operationName?: string
          query?: string
          variables?: Json
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      addresses: {
        Row: {
          address_line: string
          city: string
          country: string
          created_at: string
          delivery_instructions: string | null
          id: string
          is_default: boolean
          label: string | null
          phone: string
          state: string
          updated_at: string
          user_id: string
        }
        Insert: {
          address_line: string
          city: string
          country?: string
          created_at?: string
          delivery_instructions?: string | null
          id?: string
          is_default?: boolean
          label?: string | null
          phone: string
          state: string
          updated_at?: string
          user_id: string
        }
        Update: {
          address_line?: string
          city?: string
          country?: string
          created_at?: string
          delivery_instructions?: string | null
          id?: string
          is_default?: boolean
          label?: string | null
          phone?: string
          state?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: []
      }
      cart_items: {
        Row: {
          cart_id: string
          created_at: string
          id: string
          quantity: number
          updated_at: string
          variant_id: string
        }
        Insert: {
          cart_id: string
          created_at?: string
          id?: string
          quantity: number
          updated_at?: string
          variant_id: string
        }
        Update: {
          cart_id?: string
          created_at?: string
          id?: string
          quantity?: number
          updated_at?: string
          variant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "cart_items_cart_id_fkey"
            columns: ["cart_id"]
            isOneToOne: false
            referencedRelation: "carts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "cart_items_variant_id_fkey"
            columns: ["variant_id"]
            isOneToOne: false
            referencedRelation: "product_variants"
            referencedColumns: ["id"]
          },
        ]
      }
      carts: {
        Row: {
          created_at: string
          id: string
          updated_at: string
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          updated_at?: string
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: []
      }
      categories: {
        Row: {
          created_at: string
          description: string | null
          id: string
          image_path: string | null
          is_visible: boolean
          name: string
          slug: string
          sort_order: number
          updated_at: string
        }
        Insert: {
          created_at?: string
          description?: string | null
          id?: string
          image_path?: string | null
          is_visible?: boolean
          name: string
          slug: string
          sort_order?: number
          updated_at?: string
        }
        Update: {
          created_at?: string
          description?: string | null
          id?: string
          image_path?: string | null
          is_visible?: boolean
          name?: string
          slug?: string
          sort_order?: number
          updated_at?: string
        }
        Relationships: []
      }
      email_events: {
        Row: {
          created_at: string
          error: string | null
          id: string
          order_id: string | null
          provider_message_id: string | null
          status: Database["public"]["Enums"]["email_status"]
          template: string
          to_email: string
          user_id: string | null
        }
        Insert: {
          created_at?: string
          error?: string | null
          id?: string
          order_id?: string | null
          provider_message_id?: string | null
          status: Database["public"]["Enums"]["email_status"]
          template: string
          to_email: string
          user_id?: string | null
        }
        Update: {
          created_at?: string
          error?: string | null
          id?: string
          order_id?: string | null
          provider_message_id?: string | null
          status?: Database["public"]["Enums"]["email_status"]
          template?: string
          to_email?: string
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "email_events_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: false
            referencedRelation: "orders"
            referencedColumns: ["id"]
          },
        ]
      }
      order_items: {
        Row: {
          created_at: string
          id: string
          line_total: number
          order_id: string
          product_id: string | null
          product_name: string
          quantity: number
          sku: string | null
          unit_price: number
          variant_id: string | null
          variant_name: string
        }
        Insert: {
          created_at?: string
          id?: string
          line_total: number
          order_id: string
          product_id?: string | null
          product_name: string
          quantity: number
          sku?: string | null
          unit_price: number
          variant_id?: string | null
          variant_name: string
        }
        Update: {
          created_at?: string
          id?: string
          line_total?: number
          order_id?: string
          product_id?: string | null
          product_name?: string
          quantity?: number
          sku?: string | null
          unit_price?: number
          variant_id?: string | null
          variant_name?: string
        }
        Relationships: [
          {
            foreignKeyName: "order_items_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: false
            referencedRelation: "orders"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "order_items_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "order_items_variant_id_fkey"
            columns: ["variant_id"]
            isOneToOne: false
            referencedRelation: "product_variants"
            referencedColumns: ["id"]
          },
        ]
      }
      order_status_history: {
        Row: {
          changed_by: string | null
          created_at: string
          from_payment_status:
            | Database["public"]["Enums"]["payment_status"]
            | null
          from_status: Database["public"]["Enums"]["order_status"] | null
          id: string
          note: string | null
          order_id: string
          to_payment_status:
            | Database["public"]["Enums"]["payment_status"]
            | null
          to_status: Database["public"]["Enums"]["order_status"] | null
        }
        Insert: {
          changed_by?: string | null
          created_at?: string
          from_payment_status?:
            | Database["public"]["Enums"]["payment_status"]
            | null
          from_status?: Database["public"]["Enums"]["order_status"] | null
          id?: string
          note?: string | null
          order_id: string
          to_payment_status?:
            | Database["public"]["Enums"]["payment_status"]
            | null
          to_status?: Database["public"]["Enums"]["order_status"] | null
        }
        Update: {
          changed_by?: string | null
          created_at?: string
          from_payment_status?:
            | Database["public"]["Enums"]["payment_status"]
            | null
          from_status?: Database["public"]["Enums"]["order_status"] | null
          id?: string
          note?: string | null
          order_id?: string
          to_payment_status?:
            | Database["public"]["Enums"]["payment_status"]
            | null
          to_status?: Database["public"]["Enums"]["order_status"] | null
        }
        Relationships: [
          {
            foreignKeyName: "order_status_history_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: false
            referencedRelation: "orders"
            referencedColumns: ["id"]
          },
        ]
      }
      orders: {
        Row: {
          cancelled_at: string | null
          confirmed_at: string | null
          created_at: string
          currency: string
          customer_email: string
          customer_first_name: string
          customer_last_name: string
          customer_phone: string
          delivery_address: string
          delivery_city: string
          delivery_country: string
          delivery_fee: number
          delivery_instructions: string | null
          delivery_phone: string
          delivery_state: string
          id: string
          idempotency_key: string
          payment_method: Database["public"]["Enums"]["payment_method"]
          payment_status: Database["public"]["Enums"]["payment_status"]
          reference: string
          status: Database["public"]["Enums"]["order_status"]
          stock_deducted: boolean
          subtotal: number
          total: number
          updated_at: string
          user_id: string | null
        }
        Insert: {
          cancelled_at?: string | null
          confirmed_at?: string | null
          created_at?: string
          currency: string
          customer_email: string
          customer_first_name: string
          customer_last_name: string
          customer_phone: string
          delivery_address: string
          delivery_city: string
          delivery_country: string
          delivery_fee?: number
          delivery_instructions?: string | null
          delivery_phone: string
          delivery_state: string
          id?: string
          idempotency_key: string
          payment_method: Database["public"]["Enums"]["payment_method"]
          payment_status?: Database["public"]["Enums"]["payment_status"]
          reference: string
          status?: Database["public"]["Enums"]["order_status"]
          stock_deducted?: boolean
          subtotal: number
          total: number
          updated_at?: string
          user_id?: string | null
        }
        Update: {
          cancelled_at?: string | null
          confirmed_at?: string | null
          created_at?: string
          currency?: string
          customer_email?: string
          customer_first_name?: string
          customer_last_name?: string
          customer_phone?: string
          delivery_address?: string
          delivery_city?: string
          delivery_country?: string
          delivery_fee?: number
          delivery_instructions?: string | null
          delivery_phone?: string
          delivery_state?: string
          id?: string
          idempotency_key?: string
          payment_method?: Database["public"]["Enums"]["payment_method"]
          payment_status?: Database["public"]["Enums"]["payment_status"]
          reference?: string
          status?: Database["public"]["Enums"]["order_status"]
          stock_deducted?: boolean
          subtotal?: number
          total?: number
          updated_at?: string
          user_id?: string | null
        }
        Relationships: []
      }
      payment_events: {
        Row: {
          error: string | null
          event_id: string
          event_type: string | null
          id: string
          payload: Json
          processed_at: string | null
          provider: string
          received_at: string
        }
        Insert: {
          error?: string | null
          event_id: string
          event_type?: string | null
          id?: string
          payload: Json
          processed_at?: string | null
          provider: string
          received_at?: string
        }
        Update: {
          error?: string | null
          event_id?: string
          event_type?: string | null
          id?: string
          payload?: Json
          processed_at?: string | null
          provider?: string
          received_at?: string
        }
        Relationships: []
      }
      payments: {
        Row: {
          amount: number
          created_at: string
          currency: string
          id: string
          method: Database["public"]["Enums"]["payment_method"]
          order_id: string
          paid_at: string | null
          provider: string
          provider_reference: string | null
          raw: Json | null
          recorded_by: string | null
          status: Database["public"]["Enums"]["payment_status"]
          updated_at: string
        }
        Insert: {
          amount: number
          created_at?: string
          currency: string
          id?: string
          method: Database["public"]["Enums"]["payment_method"]
          order_id: string
          paid_at?: string | null
          provider?: string
          provider_reference?: string | null
          raw?: Json | null
          recorded_by?: string | null
          status?: Database["public"]["Enums"]["payment_status"]
          updated_at?: string
        }
        Update: {
          amount?: number
          created_at?: string
          currency?: string
          id?: string
          method?: Database["public"]["Enums"]["payment_method"]
          order_id?: string
          paid_at?: string | null
          provider?: string
          provider_reference?: string | null
          raw?: Json | null
          recorded_by?: string | null
          status?: Database["public"]["Enums"]["payment_status"]
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "payments_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: false
            referencedRelation: "orders"
            referencedColumns: ["id"]
          },
        ]
      }
      product_images: {
        Row: {
          alt_text: string | null
          created_at: string
          id: string
          is_primary: boolean
          product_id: string
          sort_order: number
          storage_path: string
        }
        Insert: {
          alt_text?: string | null
          created_at?: string
          id?: string
          is_primary?: boolean
          product_id: string
          sort_order?: number
          storage_path: string
        }
        Update: {
          alt_text?: string | null
          created_at?: string
          id?: string
          is_primary?: boolean
          product_id?: string
          sort_order?: number
          storage_path?: string
        }
        Relationships: [
          {
            foreignKeyName: "product_images_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
        ]
      }
      product_variants: {
        Row: {
          created_at: string
          id: string
          is_active: boolean
          name: string
          options: Json
          price: number | null
          product_id: string
          sku: string
          sort_order: number
          stock_quantity: number
          updated_at: string
        }
        Insert: {
          created_at?: string
          id?: string
          is_active?: boolean
          name: string
          options?: Json
          price?: number | null
          product_id: string
          sku: string
          sort_order?: number
          stock_quantity?: number
          updated_at?: string
        }
        Update: {
          created_at?: string
          id?: string
          is_active?: boolean
          name?: string
          options?: Json
          price?: number | null
          product_id?: string
          sku?: string
          sort_order?: number
          stock_quantity?: number
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "product_variants_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
        ]
      }
      products: {
        Row: {
          category_id: string
          compare_at_price: number | null
          created_at: string
          description: string | null
          id: string
          is_featured: boolean
          name: string
          price: number
          search_vector: unknown
          slug: string
          status: Database["public"]["Enums"]["product_status"]
          updated_at: string
        }
        Insert: {
          category_id: string
          compare_at_price?: number | null
          created_at?: string
          description?: string | null
          id?: string
          is_featured?: boolean
          name: string
          price: number
          search_vector?: unknown
          slug: string
          status?: Database["public"]["Enums"]["product_status"]
          updated_at?: string
        }
        Update: {
          category_id?: string
          compare_at_price?: number | null
          created_at?: string
          description?: string | null
          id?: string
          is_featured?: boolean
          name?: string
          price?: number
          search_vector?: unknown
          slug?: string
          status?: Database["public"]["Enums"]["product_status"]
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "products_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "categories"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          auth_provider: string | null
          avatar_url: string | null
          created_at: string
          email: string | null
          first_name: string | null
          id: string
          last_name: string | null
          phone: string | null
          role: Database["public"]["Enums"]["user_role"]
          updated_at: string
        }
        Insert: {
          auth_provider?: string | null
          avatar_url?: string | null
          created_at?: string
          email?: string | null
          first_name?: string | null
          id: string
          last_name?: string | null
          phone?: string | null
          role?: Database["public"]["Enums"]["user_role"]
          updated_at?: string
        }
        Update: {
          auth_provider?: string | null
          avatar_url?: string | null
          created_at?: string
          email?: string | null
          first_name?: string | null
          id?: string
          last_name?: string | null
          phone?: string | null
          role?: Database["public"]["Enums"]["user_role"]
          updated_at?: string
        }
        Relationships: []
      }
      store_settings: {
        Row: {
          bank_transfer_instructions: string | null
          contact_email: string | null
          contact_phone: string | null
          currency: string
          delivery_fee: number
          enabled_payment_methods: Database["public"]["Enums"]["payment_method"][]
          id: boolean
          low_stock_threshold: number
          restock_on_cancel: boolean
          stock_policy: Database["public"]["Enums"]["stock_policy"]
          store_name: string
          updated_at: string
        }
        Insert: {
          bank_transfer_instructions?: string | null
          contact_email?: string | null
          contact_phone?: string | null
          currency?: string
          delivery_fee?: number
          enabled_payment_methods?: Database["public"]["Enums"]["payment_method"][]
          id?: boolean
          low_stock_threshold?: number
          restock_on_cancel?: boolean
          stock_policy?: Database["public"]["Enums"]["stock_policy"]
          store_name: string
          updated_at?: string
        }
        Update: {
          bank_transfer_instructions?: string | null
          contact_email?: string | null
          contact_phone?: string | null
          currency?: string
          delivery_fee?: number
          enabled_payment_methods?: Database["public"]["Enums"]["payment_method"][]
          id?: boolean
          low_stock_threshold?: number
          restock_on_cancel?: boolean
          stock_policy?: Database["public"]["Enums"]["stock_policy"]
          store_name?: string
          updated_at?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      _deduct_order_stock: { Args: { p_order_id: string }; Returns: undefined }
      _restore_order_stock: { Args: { p_order_id: string }; Returns: undefined }
      _set_payment_status: {
        Args: {
          p_actor: string
          p_note: string
          p_order_id: string
          p_provider_reference: string
          p_raw: Json
          p_status: Database["public"]["Enums"]["payment_status"]
        }
        Returns: Json
      }
      admin_set_payment_status: {
        Args: {
          p_note?: string
          p_order_id: string
          p_status: Database["public"]["Enums"]["payment_status"]
        }
        Returns: Json
      }
      admin_update_order_status: {
        Args: {
          p_note?: string
          p_order_id: string
          p_status: Database["public"]["Enums"]["order_status"]
        }
        Returns: Json
      }
      generate_order_reference: { Args: never; Returns: string }
      is_admin: { Args: never; Returns: boolean }
      mark_order_paid: {
        Args: {
          p_order_id: string
          p_provider_reference?: string
          p_raw?: Json
        }
        Returns: Json
      }
      mark_payment_failed: {
        Args: {
          p_order_id: string
          p_provider_reference?: string
          p_raw?: Json
        }
        Returns: Json
      }
      mark_refunded: {
        Args: {
          p_order_id: string
          p_provider_reference?: string
          p_raw?: Json
        }
        Returns: Json
      }
      order_summary: { Args: { p_order_id: string }; Returns: Json }
      place_order: {
        Args: {
          p_customer: Json
          p_delivery: Json
          p_expected_total?: number
          p_idempotency_key: string
          p_items: Json
          p_payment_method?: Database["public"]["Enums"]["payment_method"]
          p_user_id: string
        }
        Returns: Json
      }
    }
    Enums: {
      email_status: "sent" | "failed"
      order_status:
        | "pending"
        | "confirmed"
        | "processing"
        | "shipped"
        | "delivered"
        | "cancelled"
      payment_method: "bank_transfer" | "pay_on_delivery" | "online"
      payment_status:
        | "not_required"
        | "pending"
        | "paid"
        | "failed"
        | "refunded"
      product_status: "draft" | "active" | "archived"
      stock_policy: "deduct_on_place" | "deduct_on_confirm"
      user_role: "customer" | "admin"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends (DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never) = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends (PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never) = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  graphql_public: {
    Enums: {},
  },
  public: {
    Enums: {
      email_status: ["sent", "failed"],
      order_status: [
        "pending",
        "confirmed",
        "processing",
        "shipped",
        "delivered",
        "cancelled",
      ],
      payment_method: ["bank_transfer", "pay_on_delivery", "online"],
      payment_status: ["not_required", "pending", "paid", "failed", "refunded"],
      product_status: ["draft", "active", "archived"],
      stock_policy: ["deduct_on_place", "deduct_on_confirm"],
      user_role: ["customer", "admin"],
    },
  },
} as const
