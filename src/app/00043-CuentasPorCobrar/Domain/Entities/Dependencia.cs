﻿using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class Dependencia : IDependencia
    {
        public string CodeRC { get; set; }
        public string Code { get; set; }
        public string Description { get; set; }
        public int Duration { get; set; }

        public List<DocumentType> GetDocumentTypes()
        {
            throw new NotImplementedException();
        }
    }
}