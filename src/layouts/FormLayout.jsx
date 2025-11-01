import MainLayout from "../layouts/MainLayout";

function FormLayout({ children }) {
  return (
    <MainLayout showBanner={true}>
      <main className="flex-1 flex justify-center py-14 px-4">
        <div className="w-full max-w-xl bg-white shadow-md rounded-md p-6 lg:sticky lg:top-20 h-fit self-start">
          {children}
        </div>
      </main>
    </MainLayout>
  );
}

export default FormLayout;
