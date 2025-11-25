import { createContext } from "react";

export const AuthContext = createContext();
export const USER_ROLES = {
  USER: 'USER',
  RECRUITER: 'RECRUITER',
  ADMIN: 'ADMIN'
};