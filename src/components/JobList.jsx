import JobCard from './JobCard';




function JobList({ jobs = [], columns = 2 }) {
  const columnClass = {
    1: 'grid-cols-1',
    2: 'grid-cols-2',
    3: 'grid-cols-3',
    4: 'grid-cols-4',
  }[columns] || 'grid-cols-2';

  return (
    <div className={`grid ${columnClass} gap-6`}>
      {jobs.map((job) => (
        <JobCard key={job.id} job={job} />
      ))}
    </div>
  );
}

export default JobList;