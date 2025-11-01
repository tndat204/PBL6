import MainLayout from "../layouts/MainLayout";

function About() {
  return (
    <MainLayout showBanner={false}>
      <h1 className="text-3xl font-bold mb-4">About Us</h1>
      <p>
        This is the about page. Here we talk about the company, mission, and more.
      </p>
    </MainLayout>
  );
}

export default About;
