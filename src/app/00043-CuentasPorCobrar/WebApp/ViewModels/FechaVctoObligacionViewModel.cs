using Domain.Entities;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class FechaVctoObligacionViewModel
    {
        public DateTime D_FechVcto { get; set; }

        public string T_FechVcto
        {
            get
            {
                return D_FechVcto.ToString(FormatosDateTime.BASIC_DATE);
            }
        }

        public FechaVctoObligacionViewModel(DateTime D_FechVcto)
        {
            this.D_FechVcto = D_FechVcto;
        }
    }
}