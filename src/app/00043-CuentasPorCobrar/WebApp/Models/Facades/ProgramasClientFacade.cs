using Domain.UnfvRepositorioClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public class ProgramasClientFacade : IProgramasClientFacade
    {
        IProgramasClient programasClient;

        public ProgramasClientFacade()
        {
            programasClient = new ProgramasClient();
        }

        public List<SelectViewModel> GetFacultades()
        {
            List<SelectViewModel> result = new List<SelectViewModel>();

            var facultades = programasClient.GetFacultades();

            if (facultades != null)
            {
                result = facultades.Select(x => new SelectViewModel()
                {
                    Value = x.CodFac,
                    TextDisplay = x.FacDesc
                }).ToList();
            }

            return result;
        }
    }
}