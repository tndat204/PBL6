import React from "react";
import "../styles/SaveButton.css";
import saveIcon from '../assets/images/save-icon.png';

const SaveButton = () => {
  return (
    <button className="save-btn">
      <img src={saveIcon} alt="icon" className="save-img opacity-70" />
    </button>
  );
};

export default SaveButton;

